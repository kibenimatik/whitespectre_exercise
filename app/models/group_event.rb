class GroupEventDatesError < StandardError; end
class GroupEvent < ApplicationRecord
  include Paranoic

  enum state: [ :draft, :published ]

  validates :name, :start_date, :end_date, :description, :location,
    presence: true, if: :published?

  def duration
    if both_dates_are_present?
      end_date.jd - start_date.jd # #jd for Julian day number
    else
      raise GroupEventDatesError, 'start_date or end_date should be set'
    end
  end

  def duration=(period)
    if start_date.present?
      self.end_date = start_date + period.to_i
    elsif end_date.present?
      self.start_date = end_date - period.to_i
    else
      raise GroupEventDatesError, 'start_date or end_date should be set'
    end
  end

  def duration?
    both_dates_are_present?
  end

  private

  def both_dates_are_present?
    [start_date, end_date].all?(&:present?)
  end
end
