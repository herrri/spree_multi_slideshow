module Spree
  class Slide < ActiveRecord::Base
    
    belongs_to :slideshow_type
    validates_presence_of :slideshow_type_id
    
    attr_accessor :attachment_width, :attachment_height
    
    has_attached_file :attachment,
            :url  => "/spree/slides/:id/:style_:basename.:extension",
            :path => ":rails_root/public/spree/slides/:id/:style_:basename.:extension",
            :styles => {
                  :thumbnail => "100x33#",
                  :small => "300x100#",
                  :medium => "600x200#",
                  :slide => "900x300#",
                  :custom => lambda {|instance| "#{instance.attachment_width}x#{instance.attachment_height}#"}
            },
            :convert_options => {
                  :thumbnail => "-gravity center",
                  :small => "-gravity center",
                  :medium => "-gravity center",
                  :slide => "-gravity center",
                  :custom => "-gravity center"
            } 
    
    #process_in_background :image UTILE MA OCCORRE ATTIVARE ANCHE LA GEMMA DELAYED-PAPERCLIP
    
    # Load S3 settings
    if (!YAML.load_file(Rails.root.join('config', 's3.yml'))[Rails.env].blank?)
      S3_OPTIONS = {
              :storage => 's3',
              :s3_credentials => Rails.root.join('config', 's3.yml')
            }
    elsif (!ENV['S3_KEY'].blank? && !ENV['S3_SECRET'].blank? && !ENV['S3_BUCKET'].blank?)
      S3_OPTIONS = {
              :storage => 's3',
              :s3_credentials => {
                :access_key_id     => ENV['S3_KEY'],
                :secret_access_key => ENV['S3_SECRET']
              },
              :bucket => ENV['S3_BUCKET']
            }
    else
      S3_OPTIONS = { :storage => 'filesystem' }
    end
    
    attachment_definitions[:attachment] = (attachment_definitions[:attachment] || {}).merge(S3_OPTIONS)
    
    def initialize(*args)
      super(*args)
      last_slide = Slide.last
      self.position = last_slide ? last_slide.position + 1 : 0
    end

  end
end