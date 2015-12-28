module Paranoic
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }
  end

  def delete
    update_column :deleted_at, Time.now
  end

  def destroy
    callbacks_result = transaction do
      run_callbacks(:destroy) do
        delete
      end
    end
    callbacks_result ? self : false
  end

  def self.included(klazz)
    klazz.extend Callbacks
  end

  module Callbacks
    def self.extended(klazz)
      klazz.define_callbacks :restore
      klazz.define_singleton_method("before_restore") do |*args, &block|
        set_callback(:restore, :before, *args, &block)
      end
      klazz.define_singleton_method("around_restore") do |*args, &block|
        set_callback(:restore, :around, *args, &block)
      end
      klazz.define_singleton_method("after_restore") do |*args, &block|
        set_callback(:restore, :after, *args, &block)
      end
    end
  end

  def restore!
    self.class.transaction do
      run_callbacks(:restore) do
        update_column :deleted_at, nil
      end
    end
    self
  end

  def deleted?
    !deleted_at.nil?
  end
end
