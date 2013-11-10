class LedgerAccountsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json
  before_action :load_ledger_account, :only => [:edit, :show, :destroy, :update, :series]

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
    load_ledger_entries
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
  end

  # POST /ledger_accounts
  # POST /ledger_accounts.json
  def create
    @ledger_account = current_user.ledger_accounts.build(strong_params)
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
    load_activity
    bucket_size = GraphHelper.calculate_optimal_bucket_size(@activity)
    json = {:series => [GraphHelper.generate_graph_series(@ledger_account.name, @activity, :balance, bucket_size),
                        GraphHelper.generate_graph_series(@ledger_account.name + ' Activity', @activity, :activity, bucket_size)]}
    respond_with json
  end

  private

  def load_ledger_account
    @ledger_account = current_user.ledger_accounts.find(ledger_account_id)
  end

  def ledger_account_id
    params[:id] || params[:ledger_account_id]
  end

  def load_ledger_entries
    @ledger_entries = apply_date_range_filter @ledger_account.ledger_entries.order(:date => :asc)
  end

  def load_activity
    set_up_date_range_filter ledger_account_path(@ledger_account)
    @activity = @ledger_account.daily_balances(@date_range_filter.start_date, @date_range_filter.end_date)
  end

  def strong_params
    params[:ledger_account].permit(:name)
  end
end
