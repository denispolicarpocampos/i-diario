require "prawn/measurement_extensions"

class LessonPlanReport
  include Prawn::View

  def self.build(entity_configuration, date_start, date_end, discipline_lesson_plan)
    new.build(entity_configuration, date_start, date_end, discipline_lesson_plan)
  end

  def initialize
    @document = Prawn::Document.new(page_size: 'A4',
                                    page_layout: :portrait,
                                    left_margin: 5.mm,
                                    right_margin: 5.mm,
                                    top_margin: 5.mm,
                                    bottom_margin: 5.mm)
  end

  def build(entity_configuration, date_start, date_end, discipline_lesson_plan)
    @entity_configuration = entity_configuration
    @date_start = date_start
    @date_end = date_end
    @discipline_lesson_plans = discipline_lesson_plan
    @gap = 10

    header
    body
    footer

    self
  end

  protected

  private

  def header

    entity_name = @entity_configuration ? @entity_configuration.entity_name : ''
    organ_name = @entity_configuration ? @entity_configuration.organ_name : ''
    title =  'Registro de conteúdos por disciplina'

    header_cell = make_cell(
      content: title,
      size: 12,
      font_style: :bold,
      background_color: 'DEDEDE',
      height: 20,
      padding: [2, 2, 4, 4],
      align: :center,
      colspan: 2
    )

    begin
      entity_logo_cell = make_cell(
        image: open(@entity_configuration.logo.url),
        fit: [50, 50],
        width: 70,
        rowspan: 4,
        position: :center,
        vposition: :center
      )
    rescue
      entity_logo_cell = make_cell(content: '', width: 70, rowspan: 4)
    end

    entity_organ_and_unity_cell = make_cell(
      content: "#{entity_name}\n#{organ_name}\n" + "#{@discipline_lesson_plans.first.lesson_plan.unity.name}",
      size: 12,
      leading: 1.5,
      align: :center,
      valign: :center,
      rowspan: 4,
      padding: [6, 0, 8, 0]
    )



    table_data = [
      [header_cell],
      [
        entity_logo_cell,
        entity_organ_and_unity_cell
      ]
    ]

    repeat(:all) do
      table(table_data, width: bounds.width) do
        cells.border_width = 0.25
        row(0).border_top_width = 0.25
        row(-1).border_bottom_width = 0.25
        column(0).border_left_width = 0.25
        column(-1).border_right_width = 0.25
      end
    end
  end

  def body
    identification_header_cell = make_cell(
      content: 'Identificação',
      size: 12,
      font_style: :bold,
      background_color: 'DEDEDE',
      height: 20,
      padding: [2, 2, 4, 4],
      align: :center,
      colspan: 5 
    )

    title_identification = [
      [identification_header_cell]
    ]

    general_information_header_cell = make_cell(
      content: 'Informações gerais',
      size: 12,
      font_style: :bold,
      background_color: 'DEDEDE',
      height: 20,
      padding: [2, 2, 4, 4],
      align: :center,
      colspan: 5 
    )

    title_general_information = [
      [general_information_header_cell]
    ]

    unity_header = make_cell(content: 'Unidade', size: 8, width: 70, font_style: :bold, background_color: 'FFFFFF', align: :center)
    discipline_header = make_cell(content: 'Disciplina', size: 8, width: 70, font_style: :bold, background_color: 'FFFFFF', align: :center)
    plan_date_header = make_cell(content: 'Data', size: 8, width: 70, font_style: :bold, background_color: 'FFFFFF', align: :center)
    classroom_header = make_cell(content: 'Turma', size: 8, width: 70, font_style: :bold, background_color: 'FFFFFF', align: :center)
    class_header = make_cell(content: 'Aulas', size: 8, width: 70, font_style: :bold, background_color: 'FFFFFF', align: :center)
    conteudo_header = make_cell(content: 'Conteúdos', size: 8, font_style: :bold, background_color: 'FFFFFF', align: :center)



    identification_headers = [
      unity_header,
      discipline_header,
      classroom_header
    ]

    general_information_headers = [
      plan_date_header,
      class_header,
      conteudo_header
    ]
    

    identification_cells = []
    general_information_cells = []

    @discipline_lesson_plans.each do |discipline_lesson_plan|

      classes = (!discipline_lesson_plan.classes ? '' : discipline_lesson_plan.classes.map { |classes| classes}.join(", "))

      unity_cell = make_cell(content:  @discipline_lesson_plans.first.lesson_plan.unity.name, size: 10, width: 240, align: :left)
      discipline_cell = make_cell(content: discipline_lesson_plan.discipline.description, size: 10, width: 80, align: :left)
      plan_date_cell = make_cell(content: discipline_lesson_plan.lesson_plan.lesson_plan_date.strftime("%d/%m/%Y"), size: 10, align: :left)
      classroom_cell = make_cell(content: discipline_lesson_plan.lesson_plan.classroom.description, size: 10, align: :left)
      class_cell = make_cell(content: classes.to_s, size: 10, width: 70, align: :left)
      conteudo_cell = make_cell(content: discipline_lesson_plan.lesson_plan.contents, size: 10, align: :left)

      identification_cells << [
        unity_cell, 
        discipline_cell, 
        classroom_cell
      ]

      general_information_cells << [
        plan_date_cell,
        class_cell,
        conteudo_cell
      ]

    end

    data = [identification_headers]
    data.concat(identification_cells)

    bounding_box([0, cursor - @gap], width: bounds.width) do
      table(title_identification, width: bounds.width) do
        cells.border_width = 0.25
        row(0).border_top_width = 0.25
        row(-1).border_bottom_width = 0.25
        column(0).border_left_width = 0.25
        column(-1).border_right_width = 0.25
      end
    end

    bounding_box([0, cursor], width: bounds.width) do
      table(data, row_colors: ['FFFFFF', 'DEDEDE'], width: bounds.width, header: true) do
        cells.border_width = 0.25
        row(0).border_top_width = 0.25
        row(-1).border_bottom_width = 0.25
        column(0).border_left_width = 0.25
        column(-1).border_right_width = 0.25
      end
    end

    data2 = [general_information_headers]
    data2.concat(general_information_cells)

    bounding_box([0, cursor - @gap], width: bounds.width) do
      table(title_general_information, width: bounds.width) do
        cells.border_width = 0.25
        row(0).border_top_width = 0.25
        row(-1).border_bottom_width = 0.25
        column(0).border_left_width = 0.25
        column(-1).border_right_width = 0.25
      end
    end

    bounding_box([0, cursor], width: bounds.width) do
      table(data2, row_colors: ['FFFFFF', 'DEDEDE'], width: bounds.width, header: true) do
        cells.border_width = 0.25
        row(0).border_top_width = 0.25
        row(-1).border_bottom_width = 0.25
        column(0).border_left_width = 0.25
        column(-1).border_right_width = 0.25
      end
    end
  end

  def footer
    repeat(:all) do
      draw_text("Data e hora: #{DateTime.now.strftime("%d/%m/%Y %H:%M")}", size: 8, at: [0, 0])

      draw_text('Assinatura do(a) professor(a):', size: 8, style: :bold, at: [20, 50])
      draw_text('____________________________', size: 8, at: [137, 50])

      draw_text('Assinatura do(a) coordenador(a):', size: 8, style: :bold, at: [279, 50])
      draw_text('____________________________', size: 8, at: [418, 50])
    end

    string = "Página <page> de <total>"
    options = { at: [bounds.right - 150, 6],
                width: 150,
                size: 8,
                align: :right }
    number_pages(string, options)
  end  
end