module fadder(cout, sum, ain, bin, cin);
    input ain, bin, cin;
    output sum, cout;

    assign cout = (ain& bin) | (bin& cin) | (cin& ain);
    assign sum = ain^ bin^ cin;


endmodule

