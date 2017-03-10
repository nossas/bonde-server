require 'csv'

class CsvReader 

  def initialize(file_name:nil, content:nil)
    @header = { }
    @registro = 1
    if file_name != nil
      @csv = CSV.read file_name
    elsif content != nil
      @csv = CSV.parse content
    end
    analise_header(@csv[0])
  end

  def next_record
    @registro += 1
    correct_record_number
  end

  def prev_record
    @registro -= 1
    correct_record_number
  end

  def rec_no
    @registro
  end

  def max_records
    @csv.size - 1
  end

  def goto(record_number)
    @registro = record_number
    correct_record_number
  end

  private

  def correct_record_number
    if @registro > 0 && @registro < @csv.size
      return true
    end

    if @registro < 1
      @registro = 1
    else
      @registro = @csv.size - 1
    end
    false
  end

  def analise_header header
    (0..header.size-1).each do |pos|
      @header[header[pos]] = pos
      
      eval("def self.#{header[pos].strip}\n@csv[@registro][#{pos}]\nend")
    end
  end
end