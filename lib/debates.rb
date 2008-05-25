# Holds the data for debates on one day
# Also knows how to output the XML data for that
class Debates
  def initialize(date)
    @date = date
    @title = ""
    @subtitle = ""
    @items = []
    @count = 1
  end
  
  def add_heading(newtitle, newsubtitle, url)
    # Only add headings if they have changed
    if newtitle != @title
      @items << MajorHeading.new(newtitle, @count, url, @date)
      @count = @count + 1
    end
    if newtitle != @title || newsubtitle != @subtitle
      @items << MinorHeading.new(newsubtitle, @count, url, @date)
      @count = @count + 1
    end
    @title = newtitle
    @subtitle = newsubtitle    
  end
  
  def add_speech(speaker, time, url, content)
    # Only add new speech if the speaker has changed
    unless speaker && last_speaker && speaker == last_speaker
      @items << Speech.new(speaker, time, url, @count, @date)
      @count = @count + 1
    end
    @items.last.append_to_content(content)
  end
  
  def last_speaker
    @items.last.speaker unless @items.empty? || !@items.last.respond_to?(:speaker)
  end
  
  def output(xml_filename)
    xml = File.open(xml_filename, 'w')
    x = Builder::XmlMarkup.new(:target => xml, :indent => 1)
    x.instruct!
    x.publicwhip do
      @items.each {|i| i.output(x)}
    end
    
    xml.close
  end
end

class MajorHeading
  def initialize(title, count, url, date)
    @title = title
    @count = count
    @url = url
    @date = date
  end
  
  def id
    "uk.org.publicwhip/debate/#{@date}.#{@count}"
  end
  
  def output(x)
    x.tag!("major-heading", @title, :id => id, :url => @url)
  end
end

class MinorHeading
  def initialize(title, count, url, date)
    @title = title
    @count = count
    @url = url
    @date = date
  end
  
  def id
    "uk.org.publicwhip/debate/#{@date}.#{@count}"
  end
  
  def output(x)
    x.tag!("minor-heading", @title, :id => id, :url => @url)
  end
end

