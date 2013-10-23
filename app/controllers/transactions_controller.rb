class TransactionsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json
  before_action :load_transaction, :only => [:edit, :show, :delete, :update, :transaction_graph]

  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = current_user.transactions.all
    set_up_date_range_filter transactions_path
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
    params[:transaction].permit([:date, :reference])
  end
end
