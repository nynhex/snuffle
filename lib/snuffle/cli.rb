require 'thor'
require 'snuffle'

module Snuffle

  class CLI < Thor

    desc_text = "Formats are text (default, to STDOUT), html, and csv. "
    desc_text << "Example: snuffle check foo/ -f html"

    desc "check PATH_TO_FILE [-f FORMAT] [-t MAX_COMPLEXITY_ALLOWED]", desc_text
    method_option :format, :type => :string, :default => 'text', :aliases => "-f"

    def check(path="./")
      summaries = []
      file_list(path).each do |path_to_file|
        summary = Snuffle::SourceFile.new(path_to_file: path_to_file).summary
        report(summary, summary.source)
        summaries << summary
      end
      create_html_index(summaries, path)
      puts results_files.join("\n")
    end

    default_task :check

    attr_accessor :last_file

    private

    def file_list(start_file)
      if File.directory?(start_file)
        return Dir.glob(File.join(start_file, "**", "*")).select{|n| n =~ /\.rb$/}
      else
        return [start_file]
      end
    end

    def report(summary, source)
      text_report(summary)
      cvs_report(summary)
      html_report(summary, source)
    end

    def create_html_index(summaries, start_path)
      return unless options['format'] == 'html'
      results_files << Snuffle::Formatters::HtmlIndex.new(summaries, start_path).export
    end

    def cvs_report(summary)
      return unless options['format'] == 'csv'
      return unless summary.cohorts.count > 0 || summary.latent_objects.count > 0
      results_files << Snuffle::Formatters::Csv.new(summary).export
    end

    def html_report(summary, source)
      return unless options['format'] == 'html'
      return unless summary.cohorts.count > 0 || summary.latent_objects.count > 0
      results_files << Snuffle::Formatters::Html.new(summary, source).export
    end

    def text_report(summary)
      return unless options['format'] == 'text'
      puts
      puts Snuffle::Formatters::Text.new(summary).export
    end

    def results_files
      @results_files ||= []
    end

  end

end
