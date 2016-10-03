START() { 
	int a, i, temp, sum;
	char b;
	intset as = {15, 16, 23, 1, 3, 100};
	write(as);
	intset bs = {};
	a = 5;
	for(i = 0 ; i < 10 ; ++i) {
		read(temp);
		as += temp; // Add an element to bs
	};
	intset cs;
	cs = as + bs;
	touch(cs, extractEvenNum, CriteriaSort) {
		sum += touch.val;
	};
	write(sum);
}
