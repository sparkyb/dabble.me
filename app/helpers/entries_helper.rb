module EntriesHelper
  def image_code(entry)
    converted_image_url = entry.image.url
    image_tag converted_image_url, data: { src: converted_image_url }, alt: "#{entry.date_format_short}"
  end
end
