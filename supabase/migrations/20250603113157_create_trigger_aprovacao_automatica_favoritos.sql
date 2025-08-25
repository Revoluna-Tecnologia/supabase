CREATE TRIGGER trigger_aprovacao_automatica_favoritos
    BEFORE INSERT ON candidaturas
    FOR EACH ROW
    EXECUTE FUNCTION aprovacao_automatica_favoritos();;
