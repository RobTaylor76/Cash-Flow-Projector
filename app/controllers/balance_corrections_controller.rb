class BalanceCorrectionsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json

  before_action :load_ledger_account
  before_action :load_balance_correction,
                  :only => [:edit, :show, :destroy, :update],
                  :after => :load_ledger_account

  def index
    set_up_date_range_filter ledger_account_balance_corrections_path(@ledger_account)
    @balance_corrections = apply_date_range_filter @ledger_account.balance_corrections
    respond_with @balance_corrections
  end

  def new
    @balance_correction = @ledger_account.balance_corrections.build
  end

  def show
    respond_with @balance_correction
  end

  def edit
  end

  def create
    @balance_correction = @ledger_account.balance_corrections.build(strong_params)
    flash[:notice] =  'Correction was successfully created.' if @balance_correction.save
    respond_with [@ledger_account, @balance_correction]
  end

  def update
    if @balance_correction.update_attributes(strong_params)
      flash[:notice] =  'Correction was successfully updated.'
    end
    respond_with [@ledger_account, @balance_correction]
  end

  def destroy
    @balance_correction.destroy
    respond_with [@ledger_account,@balance_correction]
  end

  private
  def strong_params
    params[:balance_correction].permit(:date, :balance, :reference, :correction_date)
  end

  def load_balance_correction
    @balance_correction = @ledger_account.balance_corrections.find(balance_correction_id)
  end

  def load_ledger_account
    @ledger_account ||= current_user.ledger_accounts.find(ledger_account_id)
  end

  def ledger_account_id
    params[:ledger_account_id]
  end

  def balance_correction_id
    params[:id]
  end

end
