class TransactionsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json
  before_action :load_transaction, :only => [:edit, :show, :destroy, :update]

  # GET /transactions
  # GET /transactions.json
  def index
    set_up_date_range_filter transactions_path
    @transactions = apply_date_range_filter current_user.transactions.order(:date => :asc)

    respond_with @transactions
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    respond_with @transaction
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new
    @transaction = current_user.transactions.build
    2.times { @transaction.ledger_entries.build } # shortcut to enable us to add ledger entries on form
    respond_with @transaction
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = current_user.transactions.build(strong_params)
    flash[:notice] =  'transaction was successfully created.' if @transaction.save
    respond_with @transaction
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    if @transaction.update_attributes(strong_params)
      flash[:notice] =  'transaction was successfully updated.'
    end
    respond_with @transaction
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_with @transaction
  end

  private
  def load_transaction
    @transaction = current_user.transactions.find(transaction_id)
    set_up_date_range_filter transaction_path(@transaction)
  end

  def transaction_id
    params[:id] || params[:transaction_id]
  end

  def strong_params
    params[:transaction].permit([:date,
                                :reference,
                                :approximation,
    :ledger_entries_attributes => [:id,
                                  :debit,
                                  :credit,
                                  :ledger_account_id,
                                  :analysis_code_id]])
  end
end
