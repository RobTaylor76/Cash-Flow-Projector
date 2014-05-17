class LedgerAccountsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json
  before_action :load_ledger_account, :only => [:edit, :show, :destroy, :update, :activity_graph, :analysis_code_graph, :import_statement]

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

  def activity_graph
    load_activity
    bucket_size = GraphHelper.calculate_optimal_bucket_size(@activity)
    series_data = []
    [{:series_name => @ledger_account.name,
      :daily_balances => @activity,
      :field_to_graph => :balance,
      :bucket_size => bucket_size },
    {:series_name => @ledger_account.name + 'Activity',
      :daily_balances => @activity,
      :field_to_graph => :activity,
      :bucket_size => bucket_size }].each do |series_def|

      series_data << GraphHelper.generate_line_chart_series(series_def)
    end

    json = {:series => series_data }
    respond_with json
  end

  def analysis_code_graph
    set_up_date_range_filter

    which_series = if params[:data].present? && params[:data] == 'debits'
                     :debits
                   else
                     :credits
                   end
    analysis_code_summary = LedgerAccountHelper.analysis_code_summary(@ledger_account, @date_range_filter.start_date, @date_range_filter.end_date)

    series_data = GraphHelper.generate_pie_chart_series(:series_name => 'Analysis Code Summary',
                                                  :data => analysis_code_summary[which_series],
                                                  :label_field => :analysis_code,
                                                  :value_field => :total)

    json = {:series => [series_data] }
    respond_with json
  end

  # POST - import bank statement
  def import_statement
    if params[:file_upload] && params[:file_upload][:file]
      csv_text = params[:file_upload][:file].read
      file_name = params[:file_upload][:file].original_filename
      StatementImportHelper.process_statement(current_user, @ledger_account, csv_text, file_name)
      flash[:notice] =  "File has been uploaded successfully"
    end
    respond_with @ledger_account
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
    @activity = LedgerAccountHelper.daily_balances(@ledger_account, @date_range_filter.start_date, @date_range_filter.end_date)
  end

  def strong_params
    params[:ledger_account].permit(:name)
  end
end
