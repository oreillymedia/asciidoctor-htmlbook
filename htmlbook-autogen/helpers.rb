def outline node, opts = {}
   return if (sections = node.sections).empty?
   sectnumlevels = opts[:sectnumlevels] || (node.document.attr 'sectnumlevels', 3).to_i
   toclevels = opts[:toclevels] || (node.document.attr 'toclevels', 2).to_i
   result = []
   # FIXME the level for special sections should be set correctly in the model
   # slevel will only be 0 if we have a book doctype with parts
   slevel = (first_section = sections[0]).level
   slevel = 1 if slevel == 0 && first_section.special
   result << %(<ol class="sectlevel#{slevel}">)
   sections.each do |section|
     section_num = (section.numbered && !section.caption && section.level <= sectnumlevels) ? %(#{section.sectnum} ) : nil
     if section.level < toclevels && (child_toc_level = outline section, :toclevels => toclevels, :secnumlevels => sectnumlevels)
       result << %(<li><a href="##{section.id}">#{section_num}#{section.captioned_title}</a>)
       result << child_toc_level
       result << '</li>'
     else
       result << %(<li><a href="##{section.id}">#{section_num}#{section.captioned_title}</a></li>)
     end
   end
   result << '</ol>'
   result * "\n"
end