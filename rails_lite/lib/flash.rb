require 'json'

class Flash

  def initialize(req)
    @req = req
    old_flash = req.cookies['_rails_lite_app_flash']
    if old_flash
      @old_flash = JSON.parse(old_flash)
    else
      @old_flash = {}
    end
    @new_flash = {}
    @now_flash = {}
  end

  def [](key)
    key = key.to_s
    results = []
    results += [@old_flash[key]] if @old_flash[key]
    results += [@new_flash[key]] if @new_flash[key]
    results += [@now_flash[key]] if @now_flash[key]
    results.first
  end

  def []=(key, val)
    key = key.to_s
    @new_flash[key] = val
  end

  def now
    @now_flash
  end

  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash', {path: '/', value: JSON.generate(@new_flash)})
  end

end
