class BankAccountsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json
  before_action :load_bank_account, :only => [:edit, :show, :delete, :update, :bank_account_graph]

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = current_user.bank_accounts.all
    set_up_date_range_filter bank_accounts_path
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

  def bank_accounts_graph
    @bank_accounts = current_user.bank_accounts.all
    set_up_date_range_filter bank_accounts_path

    series = []
    @bank_accounts.each do |bank_account|
      activity =  bank_account.main_ledger_account.daily_balances(@date_range_filter.start_date, @date_range_filter.end_date)
      bucket_size ||= GraphHelper.calculate_optimal_bucket_size(activity)
      series << GraphHelper.generate_graph_series(bank_account.name, activity, :balance, bucket_size)
    end
    json = {:series => series}
    respond_with json
  end

  def bank_account_graph
    load_activity
    bucket_size = GraphHelper.calculate_optimal_bucket_size(@main_activity)
    json = {:series => [GraphHelper.generate_graph_series(@bank_account.main_ledger_account.name, @main_activity, :balance, bucket_size),
                        GraphHelper.generate_graph_series(@bank_account.charges_ledger_account.name, @charges_activity, :balance, bucket_size)]}
    respond_with json
  end

  private
  def load_bank_account
    @bank_account = current_user.bank_accounts.find(bank_account_id)
    set_up_date_range_filter bank_account_path(@bank_account)
  end

  def bank_account_id
    params[:id] || params[:bank_account_id]
  end

  def strong_params
    params[:bank_account].permit(:name)
  end


  def load_activity
    @main_activity = @bank_account.main_ledger_account.daily_balances(@date_range_filter.start_date, @date_range_filter.end_date)
    @charges_activity = @bank_account.charges_ledger_account.daily_balances(@date_range_filter.start_date, @date_range_filter.end_date)
  end
end
