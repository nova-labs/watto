module EditClassesHelper
    def sanitize_signoff(signoff_name)
        signoff_name.gsub(/\[/, "&lbr").gsub(/\]/, "&rbr")
    end

    def desanitize_signoff(signoff_name)
        signoff_name.gsub(/&lbr/, "[").gsub(/&rbr/, "]")
    end
end