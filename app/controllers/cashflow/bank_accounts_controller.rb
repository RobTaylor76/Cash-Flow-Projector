module Cashflow
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
      @bank_account = current_user.bank_accounts.build(params[:bank_account])

      respond_to do |format|
        if @bank_account.save
          format.html { redirect_to bank_account_path(@bank_account), notice: 'Bank account was successfully created.' }
          format.json { render json: @bank_account, status: :created, location: bank_account_path(@bank_account) }
        else
          format.html { render action: "new" }
          format.json { render json: @bank_account.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /bank_accounts/1
    # PUT /bank_accounts/1.json
    def update
      @bank_account = current_user.bank_accounts.find(params[:id])

      respond_to do |format|
        if @bank_account.update_attributes(params[:bank_account])
          format.html { redirect_to bank_account_path(@bank_account), notice: 'Bank account was successfully updated.' }
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
      @bank_account = current_user.bank_accounts.find(params[:id])
      @bank_account.destroy
      respond_with @bank_account
    end
  end
end
