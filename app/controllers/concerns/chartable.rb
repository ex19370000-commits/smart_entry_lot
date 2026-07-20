module Chartable
  extend ActiveSupport::Concern

  private

  def build_chart_range(period)
    case period
    when 'today'
      range  = Time.current.beginning_of_day..Time.current.end_of_day
      labels = (0..23).map { |h| format('%02d:00', h) }
      keys   = labels
    when 'week'
      start  = Time.current.beginning_of_week
      range  = start..Time.current.end_of_day
      days   = (start.to_date..Date.today).to_a
      labels = days.map { |d| d.strftime('%-m/%-d') }
      keys   = days.map(&:to_s)
    when 'month'
      start  = Time.current.beginning_of_month
      range  = start..Time.current.end_of_day
      days   = (start.to_date..Date.today).to_a
      labels = days.map { |d| d.strftime('%-m/%-d') }
      keys   = days.map(&:to_s)
    else
      days   = 6.downto(0).map { |i| i.days.ago.to_date }
      range  = days.last.beginning_of_day..Time.current.end_of_day
      labels = days.map { |d| d.strftime('%-m/%-d') }
      keys   = days.map(&:to_s)
    end
    [range, labels, keys]
  end

  def group_key(period)
    period == 'today' ? "TO_CHAR(created_at AT TIME ZONE 'Asia/Tokyo', 'HH24:00')" : "DATE(created_at AT TIME ZONE 'Asia/Tokyo')"
  end
end
