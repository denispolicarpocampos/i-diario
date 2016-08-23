class RequestAccessVerifier

  def initialize(student_api_code, unity_api_code, unity_equipment_code, way, time, request_type)
    @student_api_code = student_api_code
    @unity_api_code = unity_api_code
    @unity_equipment_code = unity_equipment_code
    @way = way
    @time = time
    @request_type = request_type
  end

  def process!
    unless [1,2,3].include? @way
      self.response_msg = "Sentido inválido"
      valid = false
      return false
    end

    unless [1,2,3].include? @request_type
      self.response_msg = "Tipo de consulta inválida"
      valid = false
      return false
    end

    begin
      Time.parse @time
    rescue ArgumentError
      self.response_msg = "Data e hora inválida"
      valid = false
      return false
    end

    student = Student.find_by(api_code: @student_api_code)
    if student.blank?
      self.response_msg = "Aluno inválido"
      valid = false
      return false
    end

    unity = Unity.find_by(api_code: @unity_api_code)
    if unity.blank?
      self.response_msg = "Escola inválida"
      valid = false
      return false
    end

    unity_equipment = UnityEquipment.find_by(code: @unity_equipment_code, unity_id: unity.id)
    if unity_equipment.blank?
      self.response_msg = "Equipamento inválido"
      valid = false
      return false
    end

    student_biometric = StudentBiometric.find_by(biometric_type: unity_equipment.biometric_type, student_id: student.id)
    if student_biometric.blank?
      self.response_msg = "Biometria não cadastrada"
      valid = false
      return false
    end

    if !StudentUnityChecker.new(student, unity).present?
      self.response_msg = "Acesso negado"
      valid = false
      return false
    end

    self.biometric = student_biometric.biometric
    self.response_msg = "OK"
    valid = true
  end

  attr_reader :response_msg, :valid, :biometric

  private

  attr_writer :response_msg, :valid, :biometric
end
