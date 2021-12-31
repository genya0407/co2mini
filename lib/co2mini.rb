require "co2mini/version"
require 'hid_api'

class CO2mini
  EVENT = {
    0x50 => :co2,
    0x42 => :temp,
  }

  def initialize(key = [0x86, 0x41, 0xc9, 0xa8, 0x7f, 0x41, 0x3c, 0xac])
    @handlers = {}
    @device = HidApi.open(0x4d9, 0xa052).tap { |dev| dev.send_feature_report([0x00] + key) }
  end

  def on(event, &block)
    @handlers[event] = block
  end

  def loop
    while true do
      buf = @device.read(8)
      data = buf.get_array_of_uint8(0, 8)

      event = EVENT[data[0]]
      next unless @handlers[event]

      raw_val = data[1] << 8 | data[2]
      val = case event
      when :co2
        raw_val
      when :temp
        (raw_val / 16.0 - 273.15).round(1)
      end

      @handlers[event].call(event, val)
    end
  end
end
