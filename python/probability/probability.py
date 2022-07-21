# https://www.countbayesie.com/blog/2019/12/1/probability-and-statistics-in-90-minutes
class P:
    """
    Example of Probability as logic using Python's data model
    In this simple example these probabilites are assumed to 
    be conditionally independent.
    """
    def __init__(self,prob):
        assert prob >= 0, "probabilities can't be negative!" 
        assert prob <= 1, "probabilities can't be great than 1!"
        self.prob = prob
        
    def __repr__(self):
        return "P({})".format(self.prob)

    def __neg__(self):
        return P(1-self.prob)
    
    def __and__(self,P2):
        return P(self.prob * P2.prob)
    
    def __or__(self,P2):
        return P(self.prob + P2.prob - (self & P2).prob)

def main():    
    # facts:
    rain = P(0.3)
    forget = P(0.1)
    broken = P(0.7)
    # The probability of being wet is:

    wet = rain & (forget | broken)
    print('1') ; print(wet)

    # and logically the probability of being dry is:
    print('2') ; print(-wet)
    P(0.781) # prints by default
    return P(0.781) 

if __name__ == "__main__":
    print(main())
