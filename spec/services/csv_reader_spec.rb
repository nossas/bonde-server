
require "rails_helper"

RSpec.describe CsvReader do
  (0..1).each do |d|
    subject { (d==0) ? CsvReader.new(file_name: 'spec/services/exemplo1.csv') : 
        CsvReader.new(content: "address,name,age\n\"Paulista Avenue, 211\",Luiz,42\n\"Rue Marie Jeanne\",Robert M.,420") }

    context '#next_record' do
      it 'middle of list' do
        expect(subject.next_record).to be true
        expect(subject.rec_no).to eq(2)
      end

      it 'end of list' do
        subject.next_record

        expect(subject.next_record).to be false
        expect(subject.rec_no).to eq(2)
      end
    end

    context '#prev_record' do
      it 'middle of list' do
        subject.goto 2
        expect(subject.rec_no).to eq(2)

        expect(subject.prev_record).to be true
        expect(subject.rec_no).to eq(1)
      end

      it 'start of list' do
        expect(subject.prev_record).to be false
        expect(subject.rec_no).to eq(1)
      end
    end

    it '#rec_no' do
      expect(subject.rec_no).to eq 1
    end

    it '#max_records' do
      expect(subject.max_records).to eq(2)
    end

    context '#goto' do
      it 'too little value' do
        expect(subject.goto 0).to be false
        expect(subject.rec_no).to eq(1)
      end

      it 'too big value' do
        expect(subject.goto 5).to be false
        expect(subject.rec_no).to eq(2)
      end

      it 'valid value' do
        expect(subject.goto 2).to be true
        expect(subject.rec_no).to eq(2)
      end
    end


    it '#name[created field]' do
      expect(subject.name).to eq('Luiz')
    end

    it '#address[created field]' do
      expect(subject.address).to eq('Paulista Avenue, 211')
    end

    it '#age[created field]' do
      expect(subject.age).to eq('42')
    end
  end
end
