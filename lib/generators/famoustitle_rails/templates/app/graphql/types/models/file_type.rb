module Types
  module Models
    class FileType < Types::BaseObject
      field :id, ID, null: false
      field :filename, String, null: false
      field :byte_size, Integer, null: false
      field :content_type, String, null: false
      field :full_url, String
      field :thumb_url, String

      def full_url
        object.url
      end

      def thumb_url
        object.variable? ? object.variant(:thumb).processed.url : nil
      end

    end
  end
end
