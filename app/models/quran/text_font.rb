class Quran::TextFont < ActiveRecord::Base
  extend Quran
  extend Batchelor

  self.table_name = 'text_font'
  self.primary_key = 'id'

  belongs_to :ayah, class_name: 'Quran::Ayah', foreign_key: 'ayah_key'

  searchkick merge_mappings: true, mappings: {
    "text-font": {
      _all: {
        enabled: true
      },
      properties: {
        text: {
          type: "string",
          similarity: "my_bm25",
          term_vector: "with_positions_offsets_payloads",
          analyzer: "quran_font_to_token",
          fields: {
            lemma: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              analyzer: "quran_font_to_token_to_lemma"
            },
            stem: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              analyzer: "quran_font_to_token_to_stem"
            },
            root: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              analyzer: "quran_font_to_token_to_root"
            },
            lemma_clean: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              analyzer: "quran_font_to_token_to_lemma_normalized"
            },
            stem_clean: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              analyzer: "quran_font_to_token_to_stem_normalized"
            },
            stemmed: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              analyzer: "quran_font_to_token_to_arabic_stemmed"
            },
            ngram: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              search_analyzer: "quran_font_to_token",
              index_analyzer: "quran_font_to_token_to_arabic_ngram"
            }
          }
        }
      }
    }
  }, settings: YAML.load(File.read(File.expand_path( "#{Rails.root}/config/elasticsearch/settings.yml", __FILE__ ))), index_name: 'text-font'

  def search_data
    search_data = self.as_json(include: :ayah)
    search_data['ayah']['ayah_key'].gsub!(/:/, '_')

    search_data.merge({
      _id: self.id.gsub(/:/, '_')
      resource: self.resource,
      language: self.resource.language
    })
  end
end
