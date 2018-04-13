require_relative './spec_helper'
require_relative '../main'

RSpec.describe WebBanking do
  let(:file) { File.open("../web_index.html","r") { |f| f.read }}
  let(:page) { Nokogiri::HTML.fragment(file).css("#contract-information") }
  let(:newFile) { File.open("../transactions_web_index.html","r") { |f| f.read }}
  let(:operation_info) { Nokogiri::HTML.fragment(newFile).css(".operation-details-body") }
  let(:desc_operation_info) { Nokogiri::HTML.fragment(newFile).css(".operation-details-header") }

  before do
    expect(Watir::Browser).to receive(:new).and_return("OK")
  end

  context "Parsing account info" do
    it "Parse name" do
      expect(subject.send(:parse_name, page)).to eq("Oleg Connicov")
    end
  end

    it "Parse card currency" do
      expect(subject.send(:parse_currency, page)).to eq("USD")
    end

    it "Parse description of card" do
      expect(subject.send(:parse_nature, page)).to eq("De baza - Debit Mastercard Contactless")
    end

    it "Parse card balance" do
      expect(subject.send(:parse_balance, page)).to eq("0,08")
    end

    it "Parse transaction data" do
      expect(subject.send(:transaction_data, operation_info)).to eq ("29 March 2018 17:06")
    end

    it "Parse transaction description" do
      expect(subject.send(:transaction_description, desc_operation_info)).to eq ("Transfer to another Moldindconbank's card 5578020237140602")
    end

    it "Parse transaction amount" do
      expect(subject.send(:transaction_amount, operation_info)).to eq ("100.00 MDL")
    end
end
