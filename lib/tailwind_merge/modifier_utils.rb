# frozen_string_literal: true

module TailwindMerge
  module ModifierUtils
    IMPORTANT_MODIFIER = "!"

    def split_modifiers(class_name, separator: nil)
      separator ||= ":"
      scanner = StringScanner.new(class_name)
      modifiers = []
      bracket_depth = 0
      modifier_start = 0
      postfix_modifier_position = nil
      while !scanner.eos?
        char = scanner.getch
        if bracket_depth.zero? && char == separator
          modifiers << class_name[modifier_start...scanner.pos - 1]
          modifier_start = scanner.pos
        elsif char == "/"
          postfix_modifier_position = scanner.pos - 1
        elsif char == "["
          bracket_depth += 1
        elsif char == "]"
          bracket_depth -= 1
        end
      end
      base_class_name_with_important_modifier = modifiers.empty? ? class_name : class_name[modifier_start..-1]
      has_important_modifier = base_class_name_with_important_modifier.start_with?(IMPORTANT_MODIFIER)
      base_class_name = has_important_modifier ? base_class_name_with_important_modifier[1..-1] : base_class_name_with_important_modifier
      maybe_postfix_modifier_position = postfix_modifier_position && postfix_modifier_position > modifier_start ? postfix_modifier_position - modifier_start : false
      [modifiers, has_important_modifier, base_class_name, maybe_postfix_modifier_position]
    end

    # Sorts modifiers according to following schema:
    # - Predefined modifiers are sorted alphabetically
    # - When an arbitrary variant appears, it must be preserved which modifiers are before and after it
    def sort_modifiers(modifiers)
      if modifiers.length <= 1
        return modifiers
      end

      sorted_modifiers = []
      unsorted_modifiers = []

      modifiers.each do |modifier|
        is_arbitrary_variant = modifier[0] == "["

        if is_arbitrary_variant
          sorted_modifiers.push(unsorted_modifiers.sort, modifier)
          unsorted_modifiers = []
        else
          unsorted_modifiers.push(modifier)
        end
      end

      sorted_modifiers.push(...unsorted_modifiers.sort)

      sorted_modifiers
    end
  end
end
