# vim: ts=4 sw=4 expandtab
class Content::TafsirAyah < ActiveRecord::Base
  extend Content
  extend Batchelor

  self.table_name = 'tafsir_ayah'
  self.primary_keys = :tafsir_id, :ayah_key

  # relationships
  belongs_to :tafsir, class_name: 'Content::Tafsir'
  belongs_to :ayah,   class_name: 'Quran::Ayah', foreign_key: 'ayah_key'

  searchkick merge_mappings: true, mappings: {
    tafsir: {
      _all: { enabled: false },
      #_parent: { type: ayah }
      #_routing: { path: ayah_key }
      properties: {
        #text: { type: string, term_vector: with_positions_offsets_payloads, search_analyzer: arabic_normalized, index_analyzer: arabic_ngram }
        text: {
          type: "string",
          similarity: "my_bm25",
          term_vector: "with_positions_offsets_payloads",
          fields: {
            stemmed: {
              type: "string",
              similarity: "my_bm25",
              term_vector: "with_positions_offsets_payloads",
              search_analyzer: "arabic_normalized",
              index_analyzer: "arabic_ngram"
            }
          }
        }
      }
    }
  }, settings: YAML.load(File.read(File.expand_path( "#{Rails.root}/config/elasticsearch/settings.yml", __FILE__ ))), index_name: 'tafsir'

  def search_data
    search_data = self.as_json(include: :ayah)
    search_data['ayah']['ayah_key'].gsub!(/:/, '_')
    search_data.merge({
      _id: "#{self.tafsir.resource_id}_#{search_data['ayah']['ayah_key']}",
      resource: self.tafsir.resource.as_json,
      language: self.tafsir.resource.language.as_json,
    })
  end
end
