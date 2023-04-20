class AvatarsController < AuthenticatedController

  def create
    current_user.avatar.attach(params[:avatar])
    file = current_user.avatar

    render json: {
      message: "success",
      id: file.id,
      filename: file.filename,
      byteSize: file.byte_size,
      contentType: file.content_type,
      fullUrl: file.url,
      thumbUrl: (file.variable? ? file.variant(:thumb).processed.url : "")
    }
  end

end
