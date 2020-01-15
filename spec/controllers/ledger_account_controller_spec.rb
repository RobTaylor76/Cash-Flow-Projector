require 'spec_helper'


describe LedgerAccountsController, :type => :controller do
  before :each do
    @user = User.find_by_email('test_user@cashflowprojector.com')
    sign_in @user
  end
  it 'should allow create' do
    params = {:ledger_account => {:name => 'nombre'}}
    expect do
      post :create, params
    end.to change { @user.ledger_accounts.count }.by(1)
    @user.ledger_accounts.where(:name => 'nombre').should be_present
  end

  it 'should allow update' do
    ledger_account = @user.ledger_accounts.create!(:name => 'whatever')
    params = {:name => 'gibberish'}
    expect do
      put :update, :id => ledger_account.id, :ledger_account => params
    end.to change { @user.ledger_accounts.find(ledger_account.id).name}.to('gibberish')
  end
end
