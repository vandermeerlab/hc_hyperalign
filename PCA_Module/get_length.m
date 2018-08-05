function datalen = get_length(Q)
        for iq= 1:size(Q,2)
         datalen(iq) =size(Q{iq}.data,2);
        end
end