class BankAccountsController < ApplicationController

  respond_to :html, :json
  before_action :load_bank_account, :only => [:edit, :show, :delete, :update, :series]

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = current_user.bank_accounts.all
    respond_with @bank_accounts
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
    respond_with @bank_account
  end

  # GET /bank_accounts/new
  # GET /bank_accounts/new.json
  def new
    @bank_account = current_user.bank_accounts.build
    set_up_date_range_filter
    respond_with @bank_account
  end

  # GET /bank_accounts/1/edit
  def edit
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
    if @bank_account.update_attributes(strong_params)
      flash[:notice] =  'Bank account was successfully updated.'
    end
    respond_with @bank_account
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    @bank_account.destroy
    respond_with @bank_account
  end

  def series
    load_activity
    bucket_size = GraphHelper.calculate_optimal_bucket_size(@main_activity)
    json = {:series => [GraphHelper.generate_graph_series(@bank_account.main_ledger_account.name, @main_activity, :balance, bucket_size),
                        GraphHelper.generate_graph_series(@bank_account.charges_ledger_account.name, @charges_activity, :balance, bucket_size)]}
    respond_with json
  end

  private
  def load_bank_account
    @bank_account = current_user.bank_accounts.find(bank_account_id)
    set_up_date_range_filter
  end

  def bank_account_id
    params[:id] || params[:bank_account_id]
  end

  def strong_params
    params[:bank_account].permit(:name)
  end

  def set_up_date_range_filter
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
    @date_range_filter.filter_submit_path = bank_account_path(@bank_account)
  end

  def load_activity
    @main_activity = @bank_account.main_ledger_account.daily_balances(@date_range_filter.start_date, @date_range_filter.end_date)
    @charges_activity = @bank_account.charges_ledger_account.daily_balances(@date_range_filter.start_date, @date_range_filter.end_date)
  end
end
