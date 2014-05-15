class BankAccountsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json
  before_action :load_bank_account, :only => [:import_statement, :edit, :show, :destroy, :update, :bank_account_graph]

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = current_user.bank_accounts.includes(:main_ledger_account)
    set_up_date_range_filter bank_accounts_path
    respond_with @bank_accounts
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
    load_activity
    load_ledger_entries
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

  # POST - import bank statement
  def import_statement
    if params[:file_upload] && params[:file_upload][:file]
      csv_text = params[:file_upload][:file].read
      file_name = params[:file_upload][:file].original_filename
      StatementImportHelper.process_statement(current_user, @bank_account.main_ledger_account,csv_text, file_name)
      flash[:notice] =  "File has been uploaded successfully"
    end
    respond_with @bank_account
  end

  def bank_accounts_graph
    @bank_accounts = current_user.bank_accounts.includes(:main_ledger_account)
    set_up_date_range_filter bank_accounts_path

    series = []
    @bank_accounts.each do |bank_account|
      activity =  LedgerAccountHelper.daily_balances(bank_account.main_ledger_account,
                                                     @date_range_filter.start_date,
                                                     @date_range_filter.end_date)
      bucket_size ||= GraphHelper.calculate_optimal_bucket_size(activity)
      series << GraphHelper.generate_line_chart_series(:series_name => bank_account.name,
                                                        :daily_balances => activity,
                                                        :field_to_graph => :balance,
                                                        :bucket_size => bucket_size)
    end
    json = {:series => series}
    respond_with json
  end

  def bank_account_graph
    load_activity
    bucket_size = GraphHelper.calculate_optimal_bucket_size(@main_activity)

    series_data = []
    [{:series_name => @bank_account.main_ledger_account.name,
      :daily_balances => @main_activity,
      :field_to_graph => :balance,
      :bucket_size => bucket_size },
    {:series_name => @bank_account.main_ledger_account.name + 'Activity',
      :daily_balances => @main_activity,
      :field_to_graph => :activity,
      :bucket_size => bucket_size },
    {:series_name => @bank_account.charges_ledger_account.name,
      :daily_balances =>  @charges_activity,
    :field_to_graph => :balance,
      :bucket_size => bucket_size },
    {:series_name => @bank_account.charges_ledger_account.name + 'Activity',
      :daily_balances => @charges_activity,
      :field_to_graph => :activity,
      :bucket_size => bucket_size }].each do |series_def|

      series_data << GraphHelper.generate_line_chart_series(series_def)
    end

    json = {:series => series_data }
    respond_with json
  end

  private
  def load_bank_account
    @bank_account = current_user.bank_accounts.includes(:main_ledger_account,:charges_ledger_account).find(bank_account_id)
    set_up_date_range_filter bank_account_path(@bank_account)
  end

  def bank_account_id
    params[:id] || params[:bank_account_id]
  end

  def strong_params
    params[:bank_account].permit(:name)
  end

  def load_ledger_entries
    @ledger_entries = apply_date_range_filter @bank_account.main_ledger_account.ledger_entries.order(:date => :asc)
  end

  def load_activity
    @main_activity = LedgerAccountHelper.daily_balances(@bank_account.main_ledger_account, @date_range_filter.start_date, @date_range_filter.end_date)
    @charges_activity = LedgerAccountHelper.daily_balances(@bank_account.charges_ledger_account, @date_range_filter.start_date, @date_range_filter.end_date)
  end
end
