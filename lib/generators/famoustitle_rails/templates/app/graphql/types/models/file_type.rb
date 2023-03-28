module Types
  module Models
    class FileType < Types::BaseObject
      field :id, ID, null: false
      field :filename, String, null: false
      field :byte_size, Integer, null: false
      field :content_type, String, null: false
      field :full_url, String, null: false
      field :thumb_url, String, null: false

      def full_url
        object.url
      end

      def thumb_url
        object.variable? ? object.variant(:thumb).processed.url : ""
      end

    end
  end
end
