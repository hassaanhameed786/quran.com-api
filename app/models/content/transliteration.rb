# vim: ts=4 sw=4 expandtab
class Content::Transliteration < ActiveRecord::Base
    extend Content
    extend Batchelor

    self.table_name = 'transliteration'
    self.primary_keys = :ayah_key, :resource_id

    belongs_to :resource, class_name: 'Content::Resource'
    belongs_to :ayah,     class_name: 'Quran::Ayah', foreign_key: 'ayah_key'

    searchkick merge_mappings: true, mappings: {
      transliteration: {
        _all: {
          enabled: false
        },
        #_parent: { type: ayah }
        #_routing: { path: ayah_key }
        properties: {
          #text: { type: string, term_vector: with_positions_offsets_payloads, analyzer: english }
          text: {
            type: "string",
            similarity: "my_bm25",
            term_vector: "with_positions_offsets_payloads",
            fields: {
              stemmed: {
                type: "string",
                similarity: "my_bm25",
                term_vector:  "with_positions_offsets_payloads",
                analyzer: "standard"
              }
            }
          }
        }
      }
    }, settings: YAML.load(File.read(File.expand_path( "#{Rails.root}/config/elasticsearch/settings.yml", __FILE__ ))), index_name: 'transliteration'

    def search_data
      search_data = self.as_json(include: :ayah)
      search_data['ayah']['ayah_key'].gsub!(/:/, '_')
      search_data.merge({
        _id: "#{self.resource_id}_#{search_data['ayah']['ayah_key']}",
      })
    end
end
