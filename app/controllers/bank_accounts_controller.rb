class BankAccountsController < ApplicationController
  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = BankAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_accounts }
    end
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
    @bank_account = BankAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bank_account }
    end
  end

  # GET /bank_accounts/new
  # GET /bank_accounts/new.json
  def new
    @bank_account = BankAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bank_account }
    end
  end

  # GET /bank_accounts/1/edit
  def edit
    @bank_account = BankAccount.find(params[:id])
  end

  # POST /bank_accounts
  # POST /bank_accounts.json
  def create
    @bank_account = BankAccount.new(params[:bank_account])

    respond_to do |format|
      if @bank_account.save
        format.html { redirect_to @bank_account, notice: 'Bank account was successfully created.' }
        format.json { render json: @bank_account, status: :created, location: @bank_account }
      else
        format.html { render action: "new" }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bank_accounts/1
  # PUT /bank_accounts/1.json
  def update
    @bank_account = BankAccount.find(params[:id])

    respond_to do |format|
      if @bank_account.update_attributes(params[:bank_account])
        format.html { redirect_to @bank_account, notice: 'Bank account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    @bank_account = BankAccount.find(params[:id])
    @bank_account.destroy

    respond_to do |format|
      format.html { redirect_to bank_accounts_url }
      format.json { head :no_content }
    end
  end
end
