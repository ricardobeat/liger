module Liger
  # Formats Crystal code using `crystal tool format`
  class Formatter
    # Format the given text and return the formatted result
    def self.format(text : String) : String?
      format_from_stdin(text)
    end

    # Format a single file and return array of text edits
    def self.format_document(original_text : String, version : Int32? = nil)
      formatted = format_from_stdin(original_text)

      if formatted == original_text
        return [] of LSP::TextEdit
      end

      # Replace full document
      range = LSP::Range.new(
        LSP::Position.new(0, 0),
        LSP::Position.new(Int32::MAX, Int32::MAX)
      )

      [LSP::TextEdit.new(range, formatted)]
    end

    private def self.format_from_stdin(source : String) : String
      input = IO::Memory.new(source)
      output = IO::Memory.new
      error = IO::Memory.new

      status = Process.run(
        "crystal",
        args: ["tool", "format", "--no-commit", "-"],
        input: input,
        output: output,
        error: error,
      )

      if status.success?
        output.gets_to_end
      else
        source
      end
    end
  end
end
