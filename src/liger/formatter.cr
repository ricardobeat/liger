require "tempfile"

module Liger
  # Formats Crystal code using `crystal tool format`
  class Formatter
    # Format the given text and return the formatted result
    # Returns nil if no changes needed
    def self.format(text : String) : String?
      # Format via crystal tool format using stdin/stdout
      format_from_stdin(text)
    end

    # Format a single file and return array of text edits
    def self.format_document(original_text : String, version : Int32? = nil)
      formatted = format_from_stdin(original_text)

      if formatted == original_text
        return [] of LSP::TextEdit
      end

      # Calculate diff edits (replace full document)
      range = LSP::Range.new(
        LSP::Position.new(0, 0),
        LSP::Position.new(Int32::MAX, Int32::MAX)
      )

      [LSP::TextEdit.new(range, formatted)]
    end

    private def self.format_from_stdin(source : String) : String
      # Use crystal tool format with -i (inplace) but we need to capture output
      # Instead, we'll use --no-commit option if available, or pipe through
      Process.run(
        "crystal",
        args: ["tool", "format", "--no-commit", "-"],
        input: IO::Memory.new(source),
        error: STDERR
      ) do |process|
        output = process.output.gets_to_end
        if process.success?
          output
        else
          source # Return original on error
        end
      end
    end
  end
end
