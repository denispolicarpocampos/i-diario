class SchoolCalendarStep < ActiveRecord::Base
  include SchoolTermable

  acts_as_copy_target

  audited associated_with: :school_calendar, except: :school_calendar_id

  belongs_to :school_calendar
  has_many :ieducar_api_exam_postings, dependent: :destroy

  validate :start_at_must_not_have_conflicting_date, if: :school_calendar
  validate :end_at_must_not_have_conflicting_date, if: :school_calendar
  validate :start_at_must_be_less_than_end_at
  validate :dates_for_posting_less_than_start_date
  validate :end_date_less_than_start_date_for_posting

  scope :by_school_calendar_id, lambda { |school_calendar_id| where(school_calendar_id: school_calendar_id) }
  scope :by_unity, lambda { |unity_id| joins(:school_calendar).where(school_calendars: { unity_id: unity_id }) }
  scope :by_year, lambda { |year| joins(:school_calendar).where(school_calendars: { year: year }) }
  scope :by_step_year, lambda { |year| where('extract(year from start_at) = ?', year) }
  scope :started_after_and_before, lambda { |date|
    where(arel_table[:start_at].lteq(date)).where(arel_table[:end_at].gteq(date))
  }
  scope :posting_date_after_and_before, lambda { |date|
    where(arel_table[:start_date_for_posting].lteq(date).and(arel_table[:end_date_for_posting].gteq(date)))
  }
  scope :ordered, -> { order(:start_at) }

  delegate :unity, to: :school_calendar

  def school_calendar_step_day?(date)
    step_from_date = school_calendar.step(date)

    if !step_from_date.eql?(self)
      false
    else
      school_calendar.school_day?(date)
    end
  end

  def school_day_dates
    return if start_at.blank? || end_at.blank? || school_calendar.blank?

    dates = []

    (start_at..end_at).each do |date|
      dates << date if school_calendar.school_day?(date)
    end

    dates
  end

  def test_setting
    TestSetting.where(
      TestSetting.arel_table[:year].eq(school_calendar.year)
        .and(
          TestSetting.arel_table[:exam_setting_type].eq(ExamSettingTypes::GENERAL)
          .or(TestSetting.arel_table[:school_term].eq(school_calendar.school_term(start_at)))
        )
    )
    .order(school_term: :desc)
    .first
  end

  def school_calendar_parent
    school_calendar
  end

  private

  def steps
    return if school_calendar.blank?

    school_calendar.steps
  end

  def start_at_must_be_less_than_end_at
    return if errors[:start_at].any? || errors[:end_at].any?

    errors.add(:start_at, :must_be_less_than_end_at) if start_at.to_date >= end_at.to_date
  end

  def dates_for_posting_less_than_start_date
    if start_at.present?
      errors.add(:start_date_for_posting, :must_be_greater_than_start_at) if start_date_for_posting && start_date_for_posting < start_at
      errors.add(:end_date_for_posting, :must_be_greater_than_start_at) if end_date_for_posting && end_date_for_posting < start_at
    end
  end

  def end_date_less_than_start_date_for_posting
    if start_date_for_posting.present? && end_date_for_posting.present?
      errors.add(:end_date_for_posting, :must_be_greater_than_start_date_for_posting) if end_date_for_posting < start_date_for_posting
    end
  end

  def start_at_must_not_have_conflicting_date
    exist_conflicting_steps = SchoolCalendar.by_unity_id(unity).where.not(id: school_calendar_id).any? do |school_calendar|
      school_calendar.school_day?(start_at)
    end

    errors.add(:start_at, :must_not_have_conflicting_steps) if exist_conflicting_steps
  end

  def end_at_must_not_have_conflicting_date
    exist_conflicting_steps = SchoolCalendar.by_unity_id(unity).where.not(id: school_calendar_id).any? do |school_calendar|
      school_calendar.school_day?(end_at)
    end

    errors.add(:end_at, :must_not_have_conflicting_steps) if exist_conflicting_steps
  end
end
