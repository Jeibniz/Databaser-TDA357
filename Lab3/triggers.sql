
CREATE FUNCTION add_to_waitnglist_when_full() RETURNS trigger AS $register_to_course$
    BEGIN
        RAISE EXCEPTION 'Tigger add_to_waitnglist_when_full was trigged';
    END;
$register_to_course$ LANGUAGE plpgsql;

CREATE TRIGGER register_to_course INSTEAD OF INSERT OR UPDATE ON Registrations 
    FOR EACH ROW EXECUTE FUNCTION add_to_waitnglist_when_full();
