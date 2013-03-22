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
      @bank_account = current_user.ledger_accounts.build(params[:bank_account])

      respond_to do |format|
        if @ledger_account.save
          format.html { redirect_to ledger_account_path(@ledger_account), notice: 'Ledger account was successfully created.' }
          format.json { render json: @ledger_account, status: :created, location: @ledger_account }
        else
          format.html { render action: "new" }
          format.json { render json: @ledger_account.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /ledger_accounts/1
    # PUT /ledger_accounts/1.json
    def update
      @ledger_account = current_user.find(params[:id])

      respond_to do |format|
        if @ledger_account.update_attributes(params[:ledger_account])
          format.html { redirect_to ledger_account_path(@ledger_account), notice: 'Ledger account was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ledger_account.errors, status: :unprocessable_entity }
        end
      end
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
