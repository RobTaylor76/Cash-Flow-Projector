class LedgerAccountsController < ApplicationController
  respond_to :html, :json


  before_action :load_ledger_account, :only => [:edit, :show, :delete, :update]

  # GET /ledger_accounts
  # GET /ledger_accounts.json
  def index
    @ledger_accounts = current_user.ledger_accounts.all
    respond_with @ledger_accounts
  end

  # GET /ledger_accounts/1
  # GET /ledger_accounts/1.json
  def show
    load_activity
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
    load_activity
  end

  # POST /ledger_accounts
  # POST /ledger_accounts.json
  def create
    @ledger_account = current_user.ledger_accounts.build(params[:id])
    flash[:notice] =  'Ledger Account was successfully created.' if @ledger_account.save
    respond_with @ledger_account
  end

  # PUT /ledger_accounts/1
  # PUT /ledger_accounts/1.json
  def update
    if @ledger_account.update_attributes(strong_params)
      flash[:notice] =  'Ledger account was successfully updated.'
      load_activity
    end
    respond_with @ledger_account
  end

  # DELETE /ledger_accounts/1
  # DELETE /ledger_accounts/1.json
  def destroy
    @ledger_account.destroy
    respond_with @ledger_account
  end

  def series
    json = {"series"=>[{"name"=>"Net Sales","data"=>[[1378425600000,0.0],[1378684800000,0.0],[1378944000000,0.0],[1379203200000,0.0],[1379462400000,0.0],[1379721600000,0.0],[1379980800000,0.0],[1380240000000,0.0],[1380499200000,0.0],[1380758400000,0.0],[1381017600000,0.0],[1381276800000,0.0],[1381536000000,0.0],[1381795200000,0.0],[1382054400000,0.0],[1382313600000,0.0]]}]}
    respond_with json
  end

  private
  def load_ledger_account
    @ledger_account = current_user.ledger_accounts.find(params[:id])
  end

  def load_activity
    set_up_activity_filter
    @activity = @ledger_account.daily_balances(@date_range_filter.start_date, @date_range_filter.end_date)
  end

  def strong_params
    params[:ledger_account].permit(:name)
  end

  def set_up_activity_filter
    params[:date_range_filter] ||= {}

    if params[:date_range_filter][:start_date].present?
      params[:date_range_filter][:start_date] = Date.parse(params[:date_range_filter][:start_date])
    else
      params[:date_range_filter][:start_date] = Date.today-30
    end

    if params[:date_range_filter][:end_date].present?
      params[:date_range_filter][:end_date] = Date.parse(params[:date_range_filter][:end_date])
    else
      params[:date_range_filter][:end_date] = Date.today
    end

    @date_range_filter = DateRangeFilter.new(params[:date_range_filter])
    @date_range_filter.filter_submit_path = ledger_account_path(@ledger_account)
  end
end
