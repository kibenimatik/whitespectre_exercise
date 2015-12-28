class GroupEvent < ApplicationRecord
  include Paranoic

  enum state: [ :draft, :published ]

  validates :name, :start_date, :end_date, :description, :location,
    presence: true, if: :published?

  def duration
    if both_dates_are_present?
      end_date.jd - start_date.jd + 1# #jd for Julian day number, +1 to count start_date
    else
      'undefined'
    end
  end

  private

  def both_dates_are_present?
    [start_date, end_date].all?(&:present?)
  end
end
