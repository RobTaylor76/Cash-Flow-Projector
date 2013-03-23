module Cashflow
  class LedgerAccountsController < ApplicationController
    respond_to :html, :json
    # GET /ledger_accounts
    # GET /ledger_accounts.json
    def index
      @ledger_accounts = current_user.ledger_accounts.all
      respond_with @ledger_accounts
    end

    # GET /ledger_accounts/1
    # GET /ledger_accounts/1.json
    def show
      @ledger_account = current_user.ledger_accounts.find(params[:id])
      respond_with @ledger_account
    end

    # GET /ledger_accounts/new
    # GET /ledger_accounts/new.json
    def new
      @ledger_account = current_user.ledger_accounts.build
      respond_with @ledger_account
    end

    # GET /ledger_accounts/1/edit
    def edit
      @ledger_account = current_user.find(params[:id])
    end

    # POST /ledger_accounts
    # POST /ledger_accounts.json
    def create
      @ledger_account = current_user.ledger_accounts.build(params[:bank_account])
      flash[:notice] =  'Ledger Account was successfully created.' if @ledger_account.save
      respond_with @ledger_account
    end

    # PUT /ledger_accounts/1
    # PUT /ledger_accounts/1.json
    def update
      @ledger_account = current_user.find(params[:id])
      if @ledger_account.update_attributes(params[:ledger_account])
        flash[:notice] =  'Ledger account was successfully updated.'
      end
      respond_with @ledger_account
    end

    # DELETE /ledger_accounts/1
    # DELETE /ledger_accounts/1.json
    def destroy
      @ledger_account = current_user.find(params[:id])
      @ledger_account.destroy
      respond_with @ledger_account
    end
  end
end
