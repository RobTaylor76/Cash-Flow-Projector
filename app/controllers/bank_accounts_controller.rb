class BankAccountsController < ApplicationController

  respond_to :html, :json
  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = current_user.bank_accounts.all
    respond_with @bank_accounts
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
    @bank_account = current_user.bank_accounts.find(params[:id])
    respond_with @bank_account
  end

  # GET /bank_accounts/new
  # GET /bank_accounts/new.json
  def new
    @bank_account = current_user.bank_accounts.build
    respond_with @bank_account
  end

  # GET /bank_accounts/1/edit
  def edit
    @bank_account = current_user.bank_accounts.find(params[:id])
  end

  # POST /bank_accounts
  # POST /bank_accounts.json
  def create
    @bank_account = current_user.bank_accounts.build(strong_params)
    flash[:notice] =  'Bank account was successfully created.' if @bank_account.save
    respond_with @bank_account
  end

  # PUT /bank_accounts/1
  # PUT /bank_accounts/1.json
  def update
    @bank_account = current_user.bank_accounts.find(params[:id])
    if @bank_account.update_attributes(strong_params)
      flash[:notice] =  'Bank account was successfully updated.'
    end
    respond_with @bank_account
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    @bank_account = current_user.bank_accounts.find(params[:id])
    @bank_account.destroy
    respond_with @bank_account
  end

  private

  def strong_params
    params[:bank_account].permit(:name)
  end
end
