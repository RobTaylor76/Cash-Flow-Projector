class RecurringTransactionsController < ApplicationController
  respond_to :html, :json
  before_action :load_transaction, :only => [:edit, :show, :destroy, :update]

  # GET /recurring_transactions
  # GET /recurring_transactions.json
  def index
    @recurring_transactions = current_user.recurring_transactions.all
    respond_with @recurring_transactions
  end

  # GET /recurring_transactions/1
  # GET /recurring_transactions/1.json
  def show
    respond_with @recurring_transaction
  end

  # GET /recurring_transactions/new
  # GET /recurring_transactions/new.json
  def new
    @recurring_transaction = current_user.recurring_transactions.build
    respond_with @recurring_transaction
  end

  # GET /recurring_transactions/new
  # GET /recurring_transactions/new.json
  def edit
    respond_with @recurring_transaction
  end

  # POST /recurring_transactions
  # POST /recurring_transactions.json
  def create
    @recurring_transaction = current_user.recurring_transactions.build(strong_params)
    flash[:notice] =  'Recurring Transaction was successfully created.' if @recurring_transaction.create_recurrences
    respond_with @recurring_transaction
  end

  # PUT /recurring_transactions/1
  # PUT /recurring_transactions/1.json
  def update
    @recurring_transaction.assign_attributes(strong_params)

    if @recurring_transaction.edit_recurrences
      flash[:notice] =  'Ledger account was successfully updated.'
    end
    respond_with @recurring_transaction
  end

  # DELETE /recurring_transactions/1
  # DELETE /recurring_transactions/1.json
  def destroy
    @recurring_transaction.destroy
    respond_with @recurring_transaction
  end

  private

  def load_transaction
    @recurring_transaction = current_user.recurring_transactions.find(transaction_id)
  end

  def transaction_id
    params[:id]
  end

  def strong_params
    params[:recurring_transaction].permit([:reference, :start_date, :end_date, :amount, :percentage, :percentage_of_id, :from_id, :to_id, :frequency_id ])
  end
end

