class KnowledgeAreaLessonPlan < ActiveRecord::Base
  include Audit
  include Filterable

  acts_as_copy_target

  audited
  has_associated_audits

  belongs_to :lesson_plan, dependent: :destroy

  has_many :knowledge_area_lesson_plan_knowledge_areas, dependent: :destroy
  has_many :knowledge_areas, through: :knowledge_area_lesson_plan_knowledge_areas

  accepts_nested_attributes_for :lesson_plan

  scope :by_unity_id, lambda { |unity_id| joins(:lesson_plan).where(lesson_plans: { unity_id: unity_id }) }
  scope :by_teacher_id, lambda { |teacher_id| by_teacher_id_query(teacher_id) }
  scope :by_classroom_id, lambda { |classroom_id| joins(:lesson_plan).where(lesson_plans: { classroom_id: classroom_id }) }
  scope :by_knowledge_area_id, lambda { |knowledge_area_id| joins(:knowledge_area_lesson_plan_knowledge_areas).where(knowledge_area_lesson_plan_knowledge_areas: { knowledge_area_id: knowledge_area_id }) }
  scope :by_lesson_plan_date, lambda { |lesson_plan_date| joins(:lesson_plan).where(lesson_plans: { lesson_plan_date: lesson_plan_date }) }
  scope :by_knowledge_area_id_lesson_plan_date, lambda {|knowledge_area_id, date_start, date_end, classroom_id| joins(:lesson_plan, :knowledge_area_lesson_plan_knowledge_areas).where("case when ? = 0 then 1=1 else knowledge_area_id = ? end
             and case when ? = 0 then 1 = 1 else classroom_id = ? end
             and case when ? = '01/01/1900' then  1=1 when ? = '01/01/1900' then  1=1  else lesson_plan_date between ? and ? end",
             (knowledge_area_id == '' ? 0 : knowledge_area_id), (knowledge_area_id == '' ? 0 : knowledge_area_id), (classroom_id == '' ? 0 : classroom_id), 
             (classroom_id == '' ? 0 : classroom_id), (date_start == '' ? '01/01/1900' : date_start), 
             (date_end == '' ? '01/01/1900' : date_end), (date_start == '' ? '01/01/1900' : date_start), (date_end == '' ? '01/01/1900' : date_end)).order("lesson_plan_date ASC")}
  scope :ordered, -> { joins(:lesson_plan).order(LessonPlan.arel_table[:lesson_plan_date].desc) }

  validates :lesson_plan, presence: true
  validates :knowledge_area_ids, presence: true

  validate :uniqueness_of_knowledge_area_lesson_plan

  def knowledge_area_ids
    knowledge_areas.collect(&:id).join(',')
  end

  private

  def self.by_teacher_id_query(teacher_id)
    joins(
      :lesson_plan,
      arel_table.join(TeacherDisciplineClassroom.arel_table, Arel::Nodes::OuterJoin)
        .on(
          TeacherDisciplineClassroom.arel_table[:classroom_id]
            .eq(LessonPlan.arel_table[:classroom_id])
        )
        .join_sources
      )
      .where(TeacherDisciplineClassroom.arel_table[:teacher_id].eq(teacher_id))
  end

  def uniqueness_of_knowledge_area_lesson_plan
    return unless lesson_plan.present? && lesson_plan.classroom.present?

    knowledge_area_lesson_plans = KnowledgeAreaLessonPlan.by_classroom_id(lesson_plan.classroom_id)
      .by_knowledge_area_id(knowledge_areas.collect(&:id))
      .by_lesson_plan_date(lesson_plan.lesson_plan_date)

    knowledge_area_lesson_plans = knowledge_area_lesson_plans.where.not(id: id) if persisted?

    if knowledge_area_lesson_plans.any?
        errors.add(:lesson_plan, :uniqueness_of_knowledge_area_lesson_plan, count: knowledge_areas.split(',').count)
        lesson_plan.errors.add(:lesson_plan_date, :uniqueness_of_knowledge_area_lesson_plan, count: knowledge_areas.split(',').count)
    end
  end
end
