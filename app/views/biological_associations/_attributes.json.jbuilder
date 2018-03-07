json.extract! biological_association, :id, :biological_relationship_id, 
  :biological_association_subject_id, :biological_association_subject_type,
  :biological_association_object_id, :biological_association_object_type, 
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: biological_association 

json.subject_global_id biological_association.biological_association_subject.to_global_id.to_s
json.object_global_id biological_association.biological_association_object.to_global_id.to_s


json.biological_relationship do
  json.partial! '/biological_relationships/attributes', biological_relationship: biological_association.biological_relationship
end