class SheetCommentsController < ApplicationController
  before_action :set_sheet_comment, only: [:show ]

  def create
    @sheet_comment = SheetComment.new(sheet_comment_params)
    authorize @sheet_comment

    @sheet_comment.user = current_user

    respond_to do |format|
      if @sheet_comment.save!
        @count = @sheet_comment.order.comments.count
        flash.now[:success] = "El comentario se ha enviado correctamente."
        format.js
      else
        flash[:error] = "El comentario no se ha podido enviar."
        format.js { render layout: false, content_type: 'text/javascript' }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sheet_comment
    @sheet_comment = SheetComment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sheet_comment_params
    params.require(:sheet_comment).permit(:order_id, :text)
  end

end
