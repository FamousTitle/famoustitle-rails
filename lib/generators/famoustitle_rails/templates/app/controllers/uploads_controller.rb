class UploadsController < AuthenticatedController

  def create
    current_user.files.attach(params[:files])
    added_files = current_user.files.last(params[:files].count)
    render json: {
      message: "success",
      files: added_files.map do |file|
        {
          id: file.id,
          filename: file.filename,
          byteSize: file.byte_size,
          contentType: file.content_type,
          fullUrl: file.url,
          thumbUrl: (file.variable? ? file.variant(:thumb).processed.url : "")
        }
      end
    }
  end

  def destroy
    file = current_user.files.find(params[:id])
    file.purge if file
  end

end
