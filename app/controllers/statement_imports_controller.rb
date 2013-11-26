class StatementImportsController < ApplicationController
  include DateRangeFilterable

  respond_to :html, :json

  before_action :load_ledger_account
  before_action :load_statement_import,
                  :only => [:destroy],
                  :after => :load_ledger_account

  def index
    set_up_date_range_filter ledger_account_statement_imports_path(@ledger_account)
    @statement_imports = apply_date_range_filter @ledger_account.statement_imports.order(:date => :asc)
    respond_with @statement_imports
  end


  def show
    respond_with @statement_import
  end

  def destroy
    resource = if @statement_import.destroy
                 flash[:notice] =  'Statement was successfully deleted.'
                 [@ledger_account, @statement_import]
               else
                 @statement_import
               end
    respond_with resource
  end

  private

  def load_statement_import
    @statement_import = @ledger_account.statement_imports.find(statement_import_id)
  end

  def load_ledger_account
    @ledger_account ||= current_user.ledger_accounts.find(ledger_account_id)
  end

  def ledger_account_id
    params[:ledger_account_id]
  end

  def statement_import_id
    params[:id]
  end

end
