require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CartAddProductForm do
  before do
    @form = CartAddProductForm.new
  end

  it '1' do
    @form.size = '1'
    @form.should be_valid
  end

  it '2' do
    @form.size = '2'
    @form.should be_valid
  end

  it '0' do
    @form.size = '0'
    @form.should_not be_valid
  end

  it '-1' do
    @form.size = '-1'
    @form.should_not be_valid
  end

  it '0.1' do
    @form.size = '0.1'
    @form.should_not be_valid
  end

  it 'alphabet' do
    @form.size = 'A'
    @form.should_not be_valid
  end

  it 'hiragana' do
    @form.size = 'あ'
    @form.should_not be_valid
  end

  it 'fullwidth 1' do
    @form.size = '１'
    @form.should_not be_valid
  end
end
