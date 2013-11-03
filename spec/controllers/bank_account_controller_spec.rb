require 'spec_helper'


describe BankAccountsController do
  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    sign_in @user
  end
  it 'should allow create' do
    params = {:bank_account => {:name => 'nombre'}}
    expect do
      post :create, params
    end.to change { @user.bank_accounts.count }.by(1)
    @user.bank_accounts.last.name.should == 'nombre'
  end

  it 'should allow update' do
    bank_account = @user.bank_accounts.create!(:name => 'whatever')
    params = {:name => 'gibberish'}
    expect do
      put :update, :id => bank_account.id, :bank_account => params
    end.to change { @user.bank_accounts.find(bank_account.id).name}.to('gibberish')
  end
end
